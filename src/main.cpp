#include <iostream>
#include <string>
#include <boost/algorithm/string.hpp>
#include <stringzilla/stringzilla.hpp>
#include "absl/strings/str_cat.h"

int main() {
    std::string message = "Hello from hermetic Bazel 9 & Nix!";
    std::cout << message << std::endl;
    std::cout << "Boost uppercase: " << boost::algorithm::to_upper_copy(message) << std::endl;

    // Stringzilla usage
    namespace sz = ashvardanian::stringzilla;
    sz::string_view view = message;
    std::cout << "Stringzilla find('Nix'): " << view.find("Nix") << std::endl;

    // Abseil usage
    std::cout << absl::StrCat("Abseil joined: [", message, "]") << std::endl;
    int a = 5;
    int b = 0;
    int c = a / b;
    std::cout << c << std::endl;
    return 0;
}
