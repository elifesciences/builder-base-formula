# advised by https://console.aws.amazon.com/support/home#/case/?displayId=1989832221&language=en
# to avoid timeout on boot
dhcp-client-timeout:
    file.append:
        - name: /etc/dhcp/dhclient.conf
        - text:
            - "timeout 300;"

