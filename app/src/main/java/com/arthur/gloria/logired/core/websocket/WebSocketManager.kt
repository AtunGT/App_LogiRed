package com.arthur.gloria.logired.core.websocket

import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.Response
import okhttp3.WebSocket
import okhttp3.WebSocketListener
import java.security.cert.X509Certificate
import java.util.concurrent.TimeUnit
import javax.net.ssl.SSLContext
import javax.net.ssl.TrustManager
import javax.net.ssl.X509TrustManager

class WebSocketManager {

    private var webSocket: WebSocket? = null

    private val client: OkHttpClient by lazy {
        val trustAllCerts = arrayOf<TrustManager>(object : X509TrustManager {
            override fun checkClientTrusted(chain: Array<X509Certificate>, authType: String) {}
            override fun checkServerTrusted(chain: Array<X509Certificate>, authType: String) {}
            override fun getAcceptedIssuers(): Array<X509Certificate> = arrayOf()
        })
        val sslContext = SSLContext.getInstance("SSL").apply {
            init(null, trustAllCerts, java.security.SecureRandom())
        }
        OkHttpClient.Builder()
            .sslSocketFactory(sslContext.socketFactory, trustAllCerts[0] as X509TrustManager)
            .hostnameVerifier { _, _ -> true }
            .readTimeout(0, TimeUnit.MILLISECONDS)
            .pingInterval(20, TimeUnit.SECONDS)
            .build()
    }

    var onOpen: (() -> Unit)? = null
    var onMessage: ((String) -> Unit)? = null
    var onFailure: ((String) -> Unit)? = null
    var onClosed: (() -> Unit)? = null

    fun connect(url: String) {
        disconnect()
        val request = Request.Builder().url(url).build()
        webSocket = client.newWebSocket(request, object : WebSocketListener() {
            override fun onOpen(webSocket: WebSocket, response: Response) {
                onOpen?.invoke()
            }
            override fun onMessage(webSocket: WebSocket, text: String) {
                onMessage?.invoke(text)
            }
            override fun onFailure(webSocket: WebSocket, t: Throwable, response: Response?) {
                onFailure?.invoke(t.message ?: "Error WebSocket")
            }
            override fun onClosed(webSocket: WebSocket, code: Int, reason: String) {
                onClosed?.invoke()
            }
        })
    }

    fun send(message: String): Boolean = webSocket?.send(message) ?: false

    fun disconnect() {
        webSocket?.close(1000, "Closing")
        webSocket = null
    }
}