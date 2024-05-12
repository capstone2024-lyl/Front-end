package com.example.untitled1


import android.content.pm.PackageManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray
import org.json.JSONObject

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.example.untitled1")
                .setMethodCallHandler { call, result ->
                    if (call.method == "getInstalledApps") {
                        val apps = getInstalledApps()
                        result.success(apps)
                    }
                }
    }

    private fun getInstalledApps(): String {
        val pm: PackageManager = applicationContext.packageManager
        val apps = JSONArray()
        val packages = pm.getInstalledApplications(PackageManager.GET_META_DATA)
        for (packageInfo in packages) {
            // 시스템 앱이 아닌 경우만 처리
            if (packageInfo.flags and ApplicationInfo.FLAG_SYSTEM == 0) {
                val appName = pm.getApplicationLabel(packageInfo).toString()
                val packageName = packageInfo.packageName
                val app = JSONObject()
                app.put("appName", appName)
                app.put("packageName", packageName)
                apps.put(app)
            }
        }
        return apps.toString()
    }

}
