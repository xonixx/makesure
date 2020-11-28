
BEGIN { print check_condition_reached("[[ -d /tmp ]]") }

function check_condition_reached(condition_str,    script, res) {
    script = "bash -e <<'EOF'"
    script = script "\n" condition_str " && echo 1 || echo 0"
    script = script "\nEOF"
    print script
    script | getline res
    close(script)
    return res == 1
}
