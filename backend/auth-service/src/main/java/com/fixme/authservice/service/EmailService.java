package com.fixme.authservice.service;

import lombok.RequiredArgsConstructor;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class EmailService {

    private final JavaMailSender mailSender;

    public void sendVerificationCode(String toEmail, String code) {
        SimpleMailMessage message = new SimpleMailMessage();
        message.setTo(toEmail);
        message.setSubject("FixMe");
        message.setText(
                "Hello,\n\n" +
                        "Your FixMe account verification code is: " + code + "\n" +
                        "This code is valid for 10 minutes.\n\n" +
                        "Best regards,\n" +
                        "The FixMe Team"
        );
        mailSender.send(message);
    }
}
