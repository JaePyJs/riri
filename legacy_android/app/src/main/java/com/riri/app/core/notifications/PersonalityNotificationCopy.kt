package com.riri.app.core.notifications

import com.riri.app.domain.model.PersonalityMode

object PersonalityNotificationCopy {

    fun getNotificationText(
        mode: PersonalityMode,
        reminderTitle: String,
        snoozeCount: Int,
        daysOverdue: Int
    ): Pair<String, String> { // title, body

        return when (mode) {
            PersonalityMode.BESTIE -> when {
                daysOverdue >= 3 ->
                    Pair("Bestie... 👀",
                        "Ito na yung ika-${daysOverdue} araw mo sa '$reminderTitle'. Okay ka lang?")
                snoozeCount >= 2 ->
                    Pair("Huy! 🔔",
                        "I-snooze mo ulit? '$reminderTitle' Hindi pa rin natin magagawa nyan ng ganyan.")
                else ->
                    Pair("Hoy! Riri here 👋",
                        "Uy, reminder mo: $reminderTitle")
            }

            PersonalityMode.MALUPIT -> when {
                daysOverdue >= 3 ->
                    Pair("Day $daysOverdue. Seriously.",
                        "'$reminderTitle'. I have nothing more to say.")
                else ->
                    Pair("Get up. 🔔",
                        "$reminderTitle. Now.")
            }

            PersonalityMode.CHILL -> Pair(
                "Hey, no rush ✌️",
                "Just checking — $reminderTitle when you're ready"
            )

            PersonalityMode.TITA -> Pair(
                "Anak, naalala mo ba? 🙏",
                "Yung '$reminderTitle' mo, hindi pa tapos. Gawin mo na bago ka pa makalimot ulit."
            )
        }
    }
}
