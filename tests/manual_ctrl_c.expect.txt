
spawn ./makesure_dev -f tests/manual_ctrl_c.sh a
expect {
    "b start" {
        sleep 0.2
        send \x03
        exp_continue
    }
    "goal 'b' failed" { puts "SUCCESS" }
    "SHOULD NOT SHOW" { puts "ERROR" }
}