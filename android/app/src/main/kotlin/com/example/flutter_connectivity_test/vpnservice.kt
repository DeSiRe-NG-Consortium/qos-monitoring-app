import android.content.Intent
import android.net.VpnService
import android.os.ParcelFileDescriptor
import java.net.InetAddress

class MyVpnService : VpnService() {

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val builder = Builder()
        
        // Virtuelle VPN-Sitzung einrichten
        builder.setSession("SelectiveMobileDataVPN")
            .addAddress("10.0.0.2", 24) // Virtuelle IP-Adresse für das VPN
            .addDnsServer("8.8.8.8")

        // API-Domain auflösen und über das mobile Netzwerk leiten
        val apiDomain = "example.com"
        val apiIp = InetAddress.getByName(apiDomain).hostAddress
        builder.addRoute(apiIp, 32) // Leitet nur diese IP über das VPN

        // Optional: Nur spezifische App durch das VPN leiten
        // builder.addAllowedApplication("com.example.myapp")

        // VPN-Interface aktivieren
        val vpnInterface = builder.establish()

        // Optional: Paketfilter hinzufügen (nicht unbedingt nötig)
        Thread {
            try {
                val inputStream = ParcelFileDescriptor.AutoCloseInputStream(vpnInterface)
                val outputStream = ParcelFileDescriptor.AutoCloseOutputStream(vpnInterface)

                // Hier könntest du Netzwerkpakete lesen und weiterleiten
                // Für selektive Filterung nötig, z. B. UDP/TCP spezifische Pakete
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }.start()

        return START_STICKY
    }

    override fun onDestroy() {
        super.onDestroy()
        // VPN-Verbindung schließen
    }
}