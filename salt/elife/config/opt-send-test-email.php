<?php

$email_from = "from-user@crm.elifesciences.org"; # address displayed in client to user
$envelope_sender = "envelope-user@crm.elifesciences.org"; # address used by servers

$email_to = "{{ pillar.elife.deploy_user.email }}";
$message = "test message from aws ses civi crm";
$email_subject = "test email from civi server";
$headers = "From: " . $email_from . "\n";
$headers .= "Reply-To: " . $email_from . "\n";

mail($email_to, $email_subject, $message, $headers, "-f" . $envelope_sender);
