use warp::{http::header::HeaderValue, reply::Response, Filter, Rejection, Reply};

mod static_files;
use static_files::Assets;
#[tokio::main]
async fn main() {
    let hello = warp::path!("api" / "echo").map(|| "Hello, warp!");
    let static_files = warp::path::tail().and_then(serve_static_file);
    let routes = hello.or(static_files);
    warp::serve(routes).run(([127, 0, 0, 1], 3030)).await;
}
async fn serve_static_file(path: warp::path::Tail) -> Result<impl Reply, Rejection> {
    let path = path.as_str();
    let asset = if path.is_empty() || path == "index.html" {
        Assets::get("index.html")
    } else {
        Assets::get(path)
    };

    match asset {
        Some(file) => {
            // NOTE: this is needed because otherwise the browser will try to download the file
            let actual_path = if path.is_empty() { "index.html" } else { path };
            let mime = mime_guess::from_path(actual_path).first_or_octet_stream();
            let mut res = Response::new(file.data.into());
            res.headers_mut().insert(
                "content-type",
                HeaderValue::from_str(mime.as_ref()).unwrap(),
            );
            Ok(res)
        }
        None => Err(warp::reject::not_found()),
    }
}
