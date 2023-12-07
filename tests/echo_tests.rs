#[test]
fn echo_tests() {
    trycmd::TestCases::new().case("tests/echo/*.toml");
}
