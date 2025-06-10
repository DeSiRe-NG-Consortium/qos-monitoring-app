package com.example.flutter_connectivity_test

import android.Manifest
import android.annotation.SuppressLint
import android.telephony.*
import android.telephony.ServiceState
import androidx.core.app.ActivityCompat

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

import io.flutter.plugin.common.MethodChannel

import android.os.Build
import android.os.Bundle

import android.content.pm.PackageManager
import android.content.Context
import android.content.Intent

import kotlin.system.exitProcess
import android.net.ConnectivityManager

import android.net.NetworkCapabilities
//import android.net.NetworkRequest
import android.net.Network
//import okhttp3.OkHttpClient
//import okhttp3.Request
//import java.util.concurrent.Executors

//import android.content.SharedPreferences

class MainActivity: FlutterActivity() {

    private val CHANNEL_TYPE = "com.example.network.type"
    private val CHANNEL_STRENGTH = "com.example.network.strength"
    private val CHANNEL_BIND_NETWORK = "com.example.network.bind"

    var caSupport = false;

    //private lateinit var sharedPreferences: SharedPreferences

/* 
    override fun onCreate(savedInstanceState: Bundle?) {    
        super.onCreate(savedInstanceState)
        sharedPreferences = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)

        // Lifecycle-Observer registrieren
        //ProcessLifecycleOwner.get().lifecycle.addObserver(this)

        // Setze "isAppRunning" auf true beim Start
        //setAppRunning(true)
    }
*/

    override fun onDetachedFromWindow() {
        super.onDetachedFromWindow()
        println("App wurde über den Drawer geschlossen!")
        
        val notificationManager = getSystemService(NOTIFICATION_SERVICE) as android.app.NotificationManager
        notificationManager.cancelAll()
        
        //setAppRunning(false)
        
        exitProcess(0)
    }

/*
    private fun setAppRunning(isRunning: Boolean) {
        sharedPreferences.edit().putBoolean("flutter.isAppRunning", isRunning).apply()
    }
 */

    override fun configureFlutterEngine(flutterEngine : FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_TYPE).setMethodCallHandler { call, result ->
            if(call.method == "getNetworkType") {
                result.success(getNetworkType())
            } else {
                result.notImplemented()
            }
        }
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_STRENGTH).setMethodCallHandler { call, result ->
            if(call.method == "getNetworkStrength") {
                getSignalStrength(applicationContext, result)
                //result.success(info)
            } else {
                result.notImplemented()
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_BIND_NETWORK).setMethodCallHandler { call, result ->
            if (call.method == "bindToMobileNetwork") {

/*                    
                val connectivityManager = getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager

                // Finde das mobile Netzwerk
                val mobileNetwork = connectivityManager.allNetworks.firstOrNull { network ->
                    connectivityManager.getNetworkCapabilities(network)
                        ?.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR) == true
                }

                val executor = Executors.newSingleThreadExecutor()

                executor.execute {
                    mobileNetwork?.let { network ->
                        val request = Request.Builder()
                            .url("https://www.google.de")
                            .build()

                        // Nutze OkHttpClient mit mobilem Netzwerk
                        val client = OkHttpClient.Builder()
                            .socketFactory(network.socketFactory) // Nutzt mobile Daten
                            .build()

                        val response = client.newCall(request).execute()
                        println(response.body?.string())
                    } ?: run {
                        println("Kein mobiles Netzwerk verfügbar!")
                    }
                }
*/


                /*
                mobileNetwork?.let { network ->
                    val request = Request.Builder()
                        .url("https://example.com/api")
                        .build()

                    val client = OkHttpClient.Builder()
                        .socketFactory(network.socketFactory)
                        .build()

                    val response = client.newCall(request).execute()
                    println(response.body?.string())
                }*/





                //val success = bindToSpecificNetwork("101");

                //val success = bindToMobileNetwork(result)

                //val success = bindToMobileNetwork()//result)
                //result.success(success)

            } else if (call.method == "unbindToMobileNetwork") {
                val success = unbindToMobileNetwork()
                result.success(success)
            } else {
                result.notImplemented()
            }
        }

    }

    private fun unbindToMobileNetwork(): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val connectivityManager = getSystemService(ConnectivityManager::class.java)
            connectivityManager.bindProcessToNetwork(null);
        }
        return false
    }

    fun bindToSpecificNetwork( targetNetworkId: String) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            val connectivityManager = getSystemService(ConnectivityManager::class.java)

            // Alle verfügbaren Netzwerke abrufen
            val allNetworks: Array<Network> = connectivityManager.allNetworks

            for (network in allNetworks) {
                val networkCapabilities = connectivityManager.getNetworkCapabilities(network)

                // Nur mobile Netzwerke berücksichtigen
                if (networkCapabilities != null &&
                    networkCapabilities.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR)
                ) {
                    // Netzwerk-ID prüfen
                    if (network.toString().contains(targetNetworkId)) {
                        val success = connectivityManager.bindProcessToNetwork(network)
                        println("Erfolg: $success, Network ID: $targetNetworkId")
                        return
                    }
                }
            }
            println("Kein passendes Netzwerk mit ID $targetNetworkId gefunden")
        } else {
            println("Android-Version nicht unterstützt")
        }
    }

/* 
    private fun bindToMobileNetwork(result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val connectivityManager = getSystemService(ConnectivityManager::class.java)

            val request = NetworkRequest.Builder()
                .addTransportType(NetworkCapabilities.TRANSPORT_CELLULAR)
                //.addCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET)
                .build()

            connectivityManager.requestNetwork(request, object : ConnectivityManager.NetworkCallback() {
                override fun onAvailable(network: Network) {
                    val success = true // connectivityManager.bindProcessToNetwork(network)
                    println("Bindung an mobile Daten an $network erfolgreich: $success")
                    connectivityManager.allNetworks.forEach { network ->
                        println(network)
                    }
                    
                    result.success(success)
                }

                override fun onUnavailable() {
                    println("Kein mobiles Netzwerk verfügbar!")
                    println(connectivityManager.allNetworks.toString())
                    result.success(false)
                }
            })
        } else {
            result.success(false)
        }
    }
*/

/*  
    private fun bindToMobileNetwork(): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val connectivityManager = getSystemService(ConnectivityManager::class.java)
            connectivityManager?.allNetworks?.forEach { network ->
                println(connectivityManager.activeNetworkInfo.toString())
                println(network)
                
                val capabilities = connectivityManager.getNetworkCapabilities(network)
                println(capabilities?.hasCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET))

                if (capabilities != null 
                && capabilities.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR) 
                //&& capabilities.hasCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET)
                ) {
                    val success = connectivityManager.bindProcessToNetwork(network)
                    println("Bindung an mobile Daten an $network erfolgreich: $success")
                    println(connectivityManager.activeNetworkInfo.toString())
                    return success
                }
            }
        }
        return false
    }
*/

    @SuppressLint("MissingPermission")
    private fun getNetworkType() : Any {
        val telephonyManager = getSystemService(TELEPHONY_SERVICE) as TelephonyManager 

        when (telephonyManager.dataNetworkType) {
            TelephonyManager.NETWORK_TYPE_NR -> return "5G"
            TelephonyManager.NETWORK_TYPE_LTE -> return "4G"
            TelephonyManager.NETWORK_TYPE_HSPAP, TelephonyManager.NETWORK_TYPE_HSPA -> return "3G"
            TelephonyManager.NETWORK_TYPE_EDGE -> return "2G"
            else -> return "unknown"
        }
    }

    /*
    private fun isLTEPlus(telephonyManager: TelephonyManager): Boolean {
        val serviceState: ServiceState? = telephonyManager.serviceState
        return serviceState?.isUsingCarrierAggregation == true
    }
    */

    /* 
    private fun isLTEPlus(telephonyManager: TelephonyManager): Boolean {
        val serviceState: ServiceState? = telephonyManager.serviceState
        return if (serviceState != null) {
            try {
                //@TestApi
                val method = ServiceState::class.java.getMethod("isUsingCarrierAggregation")
                method.invoke(serviceState) as? Boolean ?: false
            } catch (e: Exception) {
                false
            }
        } else {
            false
        }
    }
    */

    private fun getSignalStrength(mvContext: Context, result: MethodChannel.Result): Map<String, Any?> {    
        val telephonyManager = getSystemService(TELEPHONY_SERVICE) as TelephonyManager

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {

                /*
                    Falls du 5G-Signalwerte brauchst, kannst du CellInfoNr statt CellInfoLte verwenden.
                    Falls du 5G (NR) oder andere Netztypen unterstützt, musst du CellIdentityNr oder CellIdentityGsm verwenden.

                    CellSignalStrengthLte ?? auch CellSignalStrengthNr
                 */

                telephonyManager.requestCellInfoUpdate(
                    mvContext.mainExecutor,
                    object : TelephonyManager.CellInfoCallback() {
                        @SuppressLint("MissingPermission")
                        override fun onCellInfo(cellInfo: List<CellInfo>) {

                            /*
                            RSRP (Reference Signal Received Power) – Signalstärke für LTE/5G
                            RSRQ (Reference Signal Received Quality) – Verhältnis von Signal zu Interferenz
                            RSSI (Received Signal Strength Indicator) – Empfangsstärke für 2G/3G
                            SINR (Signal-to-Interference-plus-Noise Ratio) – Ähnlich zu SNR, oft für LTE/5G genutzt                                
                            */

                            val cellInfoList = telephonyManager.allCellInfo

                            var name: String? = null
                            var rsrp: Int? = null
                            var rsrq: Int? = null
                            var sinr: Int? = null

                            var dBm: Int? = null

                            for (info in cellInfoList) {
                                if (info is CellInfoNr) { // Check if it's a 5G cell
                                    //println("5G");
                                    //println(cellInfo)

                                    val cellIdentity = info.cellIdentity as CellIdentityNr
                                    name = cellIdentity.operatorAlphaShort?.toString() // <-- Hier wird mAlphaShort geholt
                                    
                                    val cellSignalStrengthNr: CellSignalStrengthNr = info.cellSignalStrength as CellSignalStrengthNr
                                    rsrp = cellSignalStrengthNr.ssRsrp
                                    rsrq = cellSignalStrengthNr.ssRsrq
                                    sinr = cellSignalStrengthNr.ssSinr // SINR ≈ SNR für 5G instead LTE
                                    dBm = cellSignalStrengthNr.dbm // seems same like rsrp, but filtered for your type of connection (LTE vs. 3G)
                                    
                                    break
                                }
                                else if (info is CellInfoLte) {
                                    //println("4G");
                                    //println(cellInfo)

                                    val cellIdentity = info.cellIdentity //as CellIdentityLte
                                    name = cellIdentity.operatorAlphaShort.toString() // <-- Hier wird mAlphaShort geholt

                                    val cellSignalStrengthLte = info.cellSignalStrength //as CellSignalStrengthLte
                                    rsrp = cellSignalStrengthLte.rsrp
                                    rsrq = cellSignalStrengthLte.rsrq
                                    sinr = cellSignalStrengthLte.rssnr // SNR für LTE
                                    dBm = cellSignalStrengthLte.dbm // seems same like rsrp, but filtered for your type of connection (LTE vs. 3G)
                                    
                                    break
                                }
                            }

                            result.success(mapOf(
                                "NAME" to name,
                                "RSRP" to rsrp,
                                "RSRQ" to rsrq,
                                "SINR" to sinr,
                                "DBM" to dBm
                            ))

                        }
                })

        }
        return mapOf(
                "NAME" to "unknown",
                "RSRP" to 0,
                "RSRQ" to 0,
                "SINR" to 0,
                "DBM" to 0
            );
    }

}
