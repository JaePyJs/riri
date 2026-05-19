package com.riri.app.core.notifications

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import com.riri.app.workers.ChaosReportScheduler

class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Intent.ACTION_BOOT_COMPLETED) return
        ChaosReportScheduler.scheduleWeekly(context)
    }
}
