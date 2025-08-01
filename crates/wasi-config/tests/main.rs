use anyhow::{Result, anyhow};
use test_programs_artifacts::{CONFIG_GET_COMPONENT, foreach_config};
use wasmtime::{
    Store,
    component::{Component, Linker, ResourceTable},
};
use wasmtime_wasi::p2::{add_to_linker_async, bindings::Command};
use wasmtime_wasi::{WasiCtx, WasiCtxBuilder, WasiCtxView, WasiView};
use wasmtime_wasi_config::{WasiConfig, WasiConfigVariables};

struct Ctx {
    table: ResourceTable,
    wasi_ctx: WasiCtx,
    wasi_config_vars: WasiConfigVariables,
}

impl WasiView for Ctx {
    fn ctx(&mut self) -> WasiCtxView<'_> {
        WasiCtxView {
            ctx: &mut self.wasi_ctx,
            table: &mut self.table,
        }
    }
}

async fn run_wasi(path: &str, ctx: Ctx) -> Result<()> {
    let engine = test_programs_artifacts::engine(|config| {
        config.async_support(true);
    });
    let mut store = Store::new(&engine, ctx);
    let component = Component::from_file(&engine, path)?;

    let mut linker = Linker::new(&engine);
    add_to_linker_async(&mut linker)?;
    wasmtime_wasi_config::add_to_linker(&mut linker, |h: &mut Ctx| {
        WasiConfig::from(&h.wasi_config_vars)
    })?;

    let command = Command::instantiate_async(&mut store, &component, &linker).await?;
    command
        .wasi_cli_run()
        .call_run(&mut store)
        .await?
        .map_err(|()| anyhow!("command returned with failing exit status"))
}

macro_rules! assert_test_exists {
    ($name:ident) => {
        #[expect(unused_imports, reason = "only here to ensure name exists")]
        use self::$name as _;
    };
}

foreach_config!(assert_test_exists);

#[tokio::test(flavor = "multi_thread")]
async fn config_get() -> Result<()> {
    run_wasi(
        CONFIG_GET_COMPONENT,
        Ctx {
            table: ResourceTable::new(),
            wasi_ctx: WasiCtxBuilder::new().build(),
            wasi_config_vars: WasiConfigVariables::from_iter(vec![("hello", "world")]),
        },
    )
    .await
}
