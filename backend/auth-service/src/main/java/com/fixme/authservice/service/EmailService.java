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
        message.setSubject("FixMe - كود تفعيل الحساب");
        message.setText(
                "مرحبا,\n\n" +
                        "كود تفعيل حسابك في FixMe هو: " + code + "\n" +
                        "الكود صالح لمدة 10 دقائق.\n\n" +
                        "تحيات فريق FixMe."
        );
        mailSender.send(message);
    }
}
