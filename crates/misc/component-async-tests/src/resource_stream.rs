use anyhow::Result;
use wasmtime::component::{Accessor, AccessorTask, HostStream, Resource, StreamWriter};
use wasmtime_wasi::p2::IoView;

use super::Ctx;

pub mod bindings {
    wasmtime::component::bindgen!({
        trappable_imports: true,
        path: "wit",
        world: "read-resource-stream",
        concurrent_imports: true,
        concurrent_exports: true,
        async: true,
        with: {
            "local:local/resource-stream/x": super::ResourceStreamX,
        }
    });
}

pub struct ResourceStreamX;

impl bindings::local::local::resource_stream::HostXConcurrent for Ctx {
    async fn foo<T>(accessor: &mut Accessor<T, Self>, x: Resource<ResourceStreamX>) -> Result<()> {
        accessor.with(|mut view| {
            _ = view.get().table().get(&x)?;
            Ok(())
        })
    }
}

impl bindings::local::local::resource_stream::HostX for Ctx {
    async fn drop(&mut self, x: Resource<ResourceStreamX>) -> Result<()> {
        IoView::table(self).delete(x)?;
        Ok(())
    }
}

impl bindings::local::local::resource_stream::HostConcurrent for Ctx {
    async fn foo<T: 'static>(
        accessor: &mut Accessor<T, Self>,
        count: u32,
    ) -> wasmtime::Result<HostStream<Resource<ResourceStreamX>>> {
        struct Task {
            tx: StreamWriter<Option<Resource<ResourceStreamX>>>,

            count: u32,
        }

        impl<T> AccessorTask<T, Ctx, Result<()>> for Task {
            async fn run(self, accessor: &mut Accessor<T, Ctx>) -> Result<()> {
                let mut tx = Some(self.tx);
                for _ in 0..self.count {
                    tx = accessor
                        .with(|mut view| {
                            let item = view.get().table().push(ResourceStreamX)?;
                            Ok::<_, anyhow::Error>(tx.take().unwrap().write_all(Some(item)))
                        })?
                        .await
                        .0;
                }
                Ok(())
            }
        }

        let (tx, rx) = accessor.with(|mut view| {
            let instance = view.instance();
            instance.stream::<_, _, Option<_>>(&mut view)
        })?;
        accessor.spawn(Task { tx, count });
        Ok(rx.into())
    }
}

impl bindings::local::local::resource_stream::Host for Ctx {}
