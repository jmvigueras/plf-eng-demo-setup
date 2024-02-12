#!/bin/sh
# create votes (ramdom numbers for each option)
ab -n 550 -c 50 -p posta -T "application/x-www-form-urlencoded" http://plf-eng-votes.fortidemoscloud.com/
ab -n 765 -c 50 -p postb -T "application/x-www-form-urlencoded" http://plf-eng-votes.fortidemoscloud.com/
ab -n 469 -c 50 -p posta -T "application/x-www-form-urlencoded" http://plf-eng-votes.fortidemoscloud.com/
