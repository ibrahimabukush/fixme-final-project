package com.fixme.authservice.service;

import com.twilio.Twilio;
import com.twilio.rest.api.v2010.account.Message;
import com.twilio.type.PhoneNumber;
import jakarta.annotation.PostConstruct;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@ConditionalOnProperty(prefix = "twilio", name = "accountSid")
public class SmsService {

    @Value("${twilio.accountSid}")
    private String accountSid;

    @Value("${twilio.authToken}")
    private String authToken;

    @Value("${twilio.fromPhone}")
    private String fromPhone;

    @PostConstruct
    public void init() {
        Twilio.init(accountSid, authToken);
        System.out.println("Twilio initialized with SID: " + accountSid);
    }

    public void sendVerificationCode(String toPhone, String code) {
        // تأكد إن الرقم بصيغة دولية: +9725xxxxxxx مثلا
        String formatted = formatToInternational(toPhone);

        Message.creator(
                new PhoneNumber(formatted),     // رقم المستلم
                new PhoneNumber(fromPhone),     // رقم Twilio
                "كود التفعيل لحسابك في FixMe هو: " + code
        ).create();

        System.out.println("SMS sent to " + formatted + " with code " + code);
    }

    private String formatToInternational(String phone) {
        // مثال بسيط: نحول 0501234567 إلى +972501234567
        String p = phone.trim();

        if (p.startsWith("0")) {
            p = p.substring(1); // يشيل أول صفر
        }

        if (!p.startsWith("+972")) {
            p = "+972" + p;
        }

        return p;
    }
}
