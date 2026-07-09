#include <gtest/gtest.h>
#include <stringzilla/stringzilla.hpp>
#include <boost/algorithm/string.hpp>
#include "absl/strings/str_cat.h"

TEST(HelloTest, BoostToUpper) {
    std::string message = "hello";
    boost::algorithm::to_upper(message);
    EXPECT_EQ(message, "HELLO");
}

TEST(HelloTest, StringzillaFind) {
    namespace sz = ashvardanian::stringzilla;
    sz::string_view view = "Hello from Bazel 9!";
    EXPECT_EQ(view.find("Bazel"), 11);
}

TEST(HelloTest, AbseilStrCat) {
    std::string result = absl::StrCat("Hello", " ", "Bazel");
    EXPECT_EQ(result, "Hello Bazel");
}
