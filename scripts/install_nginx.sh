#!/bin/bash
set -e

apt-get update -y
apt-get install -y nginx
systemctl enable nginx
