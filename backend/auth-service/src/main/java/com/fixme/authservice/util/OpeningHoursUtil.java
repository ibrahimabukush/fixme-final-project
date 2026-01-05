package com.fixme.authservice.util;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.time.*;
import java.util.Map;

public class OpeningHoursUtil {

    private static final ObjectMapper mapper = new ObjectMapper();


    // openingHoursJson: {"SUN":{"open":"09:00","close":"18:00"}, ...}
    public static boolean isOpenNow(String openingHoursJson, ZoneId zoneId) {
        if (openingHoursJson == null || openingHoursJson.trim().isEmpty()) return false;

        Map<String, Map<String, String>> m;
        try {
            m = mapper.readValue(openingHoursJson, new TypeReference<>() {});
        } catch (Exception e) {
            // إذا كان نص قديم مثل "Sun-Thu 09:00-18:00" → اعتبره مش مدعوم
            return false;
        }

        ZonedDateTime now = ZonedDateTime.now(zoneId);
        DayOfWeek dow = now.getDayOfWeek(); // MON..SUN
        String key = toKey(dow);           // "MON".."SUN"

        Map<String, String> range = m.get(key);
        if (range == null) return false;

        String openStr = range.get("open");
        String closeStr = range.get("close");
        if (openStr == null || closeStr == null) return false;

        LocalTime open = LocalTime.parse(openStr);
        LocalTime close = LocalTime.parse(closeStr);
        LocalTime t = now.toLocalTime();

        // حالة عادية: 09:00 - 18:00
        if (close.isAfter(open) || close.equals(open)) {
            return !t.isBefore(open) && t.isBefore(close);
        }

        // حالة over-night: 22:00 - 02:00
        return !t.isBefore(open) || t.isBefore(close);
    }

    private static String toKey(DayOfWeek d) {
        return switch (d) {
            case MONDAY -> "MON";
            case TUESDAY -> "TUE";
            case WEDNESDAY -> "WED";
            case THURSDAY -> "THU";
            case FRIDAY -> "FRI";
            case SATURDAY -> "SAT";
            case SUNDAY -> "SUN";
        };
    }
}
