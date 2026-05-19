package com.riri.app.ui.components

import com.riri.app.R

enum class DashboardState {
    EMPTY,
    READY,
    WORKING,
    SUCCESS,
    OVERDUE,
    ANGRY,
    BARKADA,
    STREAK,
    CHAOS_REPORT,
    THINKING,
    EMBARRASSED,
    CONFIDENT,
    INACTIVE,
    ABANDONED,
    ACHIEVEMENT
}

object RiriAssetMapper {
    fun getDrawableForState(state: DashboardState): Int {
        return when (state) {
            DashboardState.EMPTY -> R.drawable.welcoming
            DashboardState.READY -> R.drawable.ready
            DashboardState.WORKING -> R.drawable.whispering_nudge
            DashboardState.SUCCESS -> R.drawable.confetti_explosion
            DashboardState.OVERDUE -> R.drawable.overdue_alert
            DashboardState.ANGRY -> R.drawable.angry
            DashboardState.BARKADA -> R.drawable.barkada_mode
            DashboardState.STREAK -> if (Math.random() > 0.5) R.drawable.streak_celebration else R.drawable.hype_jump
            DashboardState.CHAOS_REPORT -> R.drawable.chaos_report_laugh
            DashboardState.THINKING -> R.drawable.thinking
            DashboardState.EMBARRASSED -> R.drawable.embarrassed
            DashboardState.CONFIDENT -> R.drawable.confident_suggestion
            DashboardState.INACTIVE -> R.drawable.inactive
            DashboardState.ABANDONED -> R.drawable.abandoned_app
            DashboardState.ACHIEVEMENT -> R.drawable.achievement
        }
    }

    fun getGenZCopyForState(state: DashboardState): String {
        return when (state) {
            DashboardState.EMPTY -> "Huy! Wala ka pang tasks. Start na tayo?"
            DashboardState.READY -> "Game na! Ano gagawin natin today?"
            DashboardState.WORKING -> "Focus lang, bestie. Wag muna mag-scroll sa TikTok."
            DashboardState.SUCCESS -> "Slay! Tapos na yung task. Deserve ang iced coffee!"
            DashboardState.OVERDUE -> "Huy! Galit na si mama. Overdue na 'to oh!"
            DashboardState.ANGRY -> "Seryoso ba? Pang-ilang snooze na 'yan?"
            DashboardState.BARKADA -> "Uy, check mo barkada mo. Mas masipag pa sila sa'yo."
            DashboardState.STREAK -> "Sheesh! Sunog yung streak natin! 🔥"
            DashboardState.CHAOS_REPORT -> "Eto na receipts mo for the week. Chaotic as usual."
            DashboardState.THINKING -> "Wait lang... pinag-iisipan ko pa kung paano ka tutulungan."
            DashboardState.EMBARRASSED -> "Oops... sorry na. My bad."
            DashboardState.CONFIDENT -> "I gotchu! Eto na yung best suggestion ko."
            DashboardState.INACTIVE -> "Buhay ka pa ba? Miss na kita... char."
            DashboardState.ABANDONED -> "Iniwan mo na ako... okay lang, sanay naman ako."
            DashboardState.ACHIEVEMENT -> "Wow! Achievement unlocked! Proud of you!"
        }
    }
}
