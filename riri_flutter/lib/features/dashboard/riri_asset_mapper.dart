import 'dart:math';

enum DashboardState {
  empty,
  ready,
  working,
  success,
  overdue,
  angry,
  barkada,
  streak,
  chaosReport,
  thinking,
  embarrassed,
  confident,
  inactive,
  abandoned,
  achievement
}

class RiriAssetMapper {
  static String getAssetPath(DashboardState state) {
    const base = 'assets/stickers/';
    switch (state) {
      case DashboardState.empty:
        return '${base}Welcoming.webp';
      case DashboardState.ready:
        return '${base}Ready.webp';
      case DashboardState.working:
        return '${base}Whispering Nudge.webp';
      case DashboardState.success:
        return '${base}Confetti_Explosion.webp';
      case DashboardState.overdue:
        return '${base}Overdue_Alert.webp';
      case DashboardState.angry:
        return '${base}Angry.webp';
      case DashboardState.barkada:
        return '${base}Barkada Mode.webp';
      case DashboardState.streak:
        return Random().nextBool() 
            ? '${base}Streak_Celebration.webp' 
            : '${base}Hype_Jump.webp';
      case DashboardState.chaosReport:
        return '${base}Chaos_Report_Laugh.webp';
      case DashboardState.thinking:
        return '${base}Thinking.webp';
      case DashboardState.embarrassed:
        return '${base}Embarrassed.webp';
      case DashboardState.confident:
        return '${base}Confident_Suggestion.webp';
      case DashboardState.inactive:
        return '${base}Inactive.webp';
      case DashboardState.abandoned:
        return '${base}Abandoned_App.webp';
      case DashboardState.achievement:
        return '${base}Achievement.webp';
    }
  }

  static String getGenZCopy(DashboardState state) {
    switch (state) {
      case DashboardState.empty:
        return 'Huy! Wala ka pang tasks. Start na tayo? ✨';
      case DashboardState.ready:
        return 'Game na! Ano gagawin natin today? 🚀';
      case DashboardState.working:
        return 'Focus lang tayo. Wag muna mag-scroll sa TikTok. 📱';
      case DashboardState.success:
        return 'Slay! Tapos na yung task. Deserve ang iced coffee! 💅';
      case DashboardState.overdue:
        return 'Huy! Galit na si mama. Overdue na \'to oh! 🚨';
      case DashboardState.angry:
        return 'Seryoso ba? Pang-ilang snooze na \'yan? 💀';
      case DashboardState.barkada:
        return 'Uy, check mo barkada mo. Mas masipag pa sila sa\'yo. 😂';
      case DashboardState.streak:
        return 'Sheesh! Sunog yung streak natin! 🔥';
      case DashboardState.chaosReport:
        return 'Eto na receipts mo for the week. Chaotic as usual. 🧾';
      case DashboardState.thinking:
        return 'Wait lang... pinag-iisipan ko pa kung paano ka tutulungan. 🤔';
      case DashboardState.embarrassed:
        return 'Oops... sorry na. My bad. 🥺';
      case DashboardState.confident:
        return 'I gotchu! Eto na yung best suggestion ko. 😎';
      case DashboardState.inactive:
        return 'Buhay ka pa ba? Miss na kita... char. 🧸';
      case DashboardState.abandoned:
        return 'Iniwan mo na ako... okay lang, sanay naman ako. 💔';
      case DashboardState.achievement:
        return 'Wow! Achievement unlocked! Proud of you! 🏆';
    }
  }
}
