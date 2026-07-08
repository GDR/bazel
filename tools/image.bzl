"""Helper macros for building and loading OCI images."""

load("@rules_pkg//pkg:tar.bzl", "pkg_tar")
load("@rules_oci//oci:defs.bzl", "oci_image", "oci_load")

def cc_image(name, binary, base = "@distroless_cc", repo_tags = None):
    """Builds a pkg_tar containing the binary, puts it in an oci_image, and sets up oci_load.

    Args:
      name: The name of the oci_load target.
      binary: The target label of the C++ binary to package.
      base: The base image to build on top of.
      repo_tags: The tags to assign to the loaded image.
    """
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

def jvm_image(name, deploy_jar, base = "@distroless_java", repo_tags = None):
    """Builds a pkg_tar containing the deploy jar, puts it in an oci_image, and sets up oci_load for Java.

    Args:
      name: The name of the oci_load target.
      deploy_jar: The target label of the deployable Java JAR to package.
      base: The base Java image to build on top of.
      repo_tags: The tags to assign to the loaded image.
    """
    tar_name = name + "_tar"
    image_name = name + "_img"
    
    pkg_tar(
        name = tar_name,
        srcs = [deploy_jar],
        package_dir = "/app",
    )
    
    # Extract jar name from label (e.g., ":main_deploy.jar" -> "main_deploy.jar")
    jar_name = deploy_jar.split(":")[-1]
    
    oci_image(
        name = image_name,
        base = base,
        tars = [":" + tar_name],
        entrypoint = [
            "java",
            "-jar",
            "/app/" + jar_name,
        ],
    )
    
    oci_load(
        name = name,
        image = ":" + image_name,
        repo_tags = repo_tags or [name + ":latest"],
    )

