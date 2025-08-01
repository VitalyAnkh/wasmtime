use super::PREOPENED_DIR_NAME;
use crate::check::artifacts_dir;
use anyhow::{Result, anyhow};
use std::path::Path;
use wasmtime::component::{Component, Linker, ResourceTable};
use wasmtime::{Config, Engine, Store};
use wasmtime_wasi::p2::bindings::sync::Command;
use wasmtime_wasi::{DirPerms, FilePerms, WasiCtx, WasiCtxView};
use wasmtime_wasi_nn::wit::WasiNnView;
use wasmtime_wasi_nn::{Backend, InMemoryRegistry, wit::WasiNnCtx};

/// Run a wasi-nn test program. This is modeled after
/// `crates/wasi/tests/all/main.rs` but still uses the older preview1 API for
/// file reads.
pub fn run(path: &str, backend: Backend, preload_model: bool) -> Result<()> {
    let path = Path::new(path);
    let engine = Engine::new(&Config::new())?;
    let mut linker = Linker::new(&engine);
    wasmtime_wasi_nn::wit::add_to_linker(&mut linker, |c: &mut Ctx| {
        WasiNnView::new(&mut c.table, &mut c.wasi_nn)
    })?;
    wasmtime_wasi::p2::add_to_linker_sync(&mut linker)?;
    let module = Component::from_file(&engine, path)?;
    let mut store = Store::new(&engine, Ctx::new(&artifacts_dir(), preload_model, backend)?);
    let command = Command::instantiate(&mut store, &module, &linker)?;
    let result = command.wasi_cli_run().call_run(&mut store)?;
    result.map_err(|_| anyhow!("failed to run command"))
}

/// The host state for running wasi-nn component tests.
struct Ctx {
    wasi: WasiCtx,
    wasi_nn: WasiNnCtx,
    table: ResourceTable,
}

impl Ctx {
    fn new(preopen_dir: &Path, preload_model: bool, mut backend: Backend) -> Result<Self> {
        let mut builder = WasiCtx::builder();
        builder.inherit_stdio().preopened_dir(
            preopen_dir,
            PREOPENED_DIR_NAME,
            DirPerms::READ,
            FilePerms::READ,
        )?;
        let wasi = builder.build();

        let mut registry = InMemoryRegistry::new();
        let mobilenet_dir = artifacts_dir();
        if preload_model {
            registry.load((backend).as_dir_loadable().unwrap(), &mobilenet_dir)?;
        }
        let wasi_nn = WasiNnCtx::new([backend], registry.into());

        let table = ResourceTable::new();

        Ok(Self {
            wasi,
            wasi_nn,
            table,
        })
    }
}

impl wasmtime_wasi::WasiView for Ctx {
    fn ctx(&mut self) -> WasiCtxView<'_> {
        WasiCtxView {
            ctx: &mut self.wasi,
            table: &mut self.table,
        }
    }
}
