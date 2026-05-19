package com.riri.app

import android.app.Application
import com.riri.app.di.appModule
import org.koin.android.ext.koin.androidContext
import org.koin.core.context.startKoin

class RiriApp : Application() {
    override fun onCreate() {
        super.onCreate()
        startKoin {
            androidContext(this@RiriApp)
            modules(appModule)
        }
    }
}
