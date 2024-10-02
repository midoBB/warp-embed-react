use rust_embed::RustEmbed;

#[derive(RustEmbed)]
#[folder = "vite-project/dist/"]
pub struct Assets;

