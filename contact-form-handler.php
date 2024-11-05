<?php
$headers = "From: info@ntog.org\r\n";
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $name = htmlspecialchars($_POST['name']);
    $email = filter_var($_POST['email'], FILTER_SANITIZE_EMAIL);
    $message = htmlspecialchars($_POST['message']);

    $to = 'info@ntog.org';
    $subject = 'New Contact Form Submission';
    $body = "Name: $name\nEmail: $email\n\nMessage:\n$message";
    $headers = "From: $email";

    if (mail($to, $subject, $body, $headers)) {
        echo 'Thank you for contacting us. We will get back to you shortly.';
    } else {
        echo 'There was an error sending your message. Please try again later.';
    }
}
?>
