load("@rules_pkg//pkg:tar.bzl", "pkg_tar")
load("@rules_oci//oci:defs.bzl", "oci_image", "oci_load")

def cc_image(name, binary, base = "@distroless_cc", repo_tags = None):
    tar_name = name + "_tar"
    image_name = name + "_img"
    
    pkg_tar(
        name = tar_name,
        srcs = [binary],
        package_dir = "/app",
    )
    
    # Extract binary name from label (e.g., ":hello" -> "hello")
    binary_name = binary.split(":")[-1]
    
    oci_image(
        name = image_name,
        base = base,
        tars = [":" + tar_name],
        entrypoint = ["/app/" + binary_name],
    )
    
    oci_load(
        name = name,
        image = ":" + image_name,
        repo_tags = repo_tags or [name + ":latest"],
    )
