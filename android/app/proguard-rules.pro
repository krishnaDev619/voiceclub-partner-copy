# Retain Hyperverge SDK classes
-keep class co.hyperverge.hvnfcsdk.** { *; }
-dontwarn co.hyperverge.hvnfcsdk.adapters.HVNFCAdapter
-dontwarn co.hyperverge.hvnfcsdk.listeners.NFCParserStatus
-dontwarn co.hyperverge.hvnfcsdk.model.HVNFCError
-dontwarn co.hyperverge.hvnfcsdk.views.ProgressWheel

# Retain kotlinx.parcelize classes and suppress warnings
-keep @kotlinx.parcelize.Parcelize class * { *; }
-keep class kotlinx.parcelize.** { *; }
-dontwarn kotlinx.parcelize.Parcelize

# Retain BouncyCastle cryptography-related classes
-keep class org.bouncycastle.** { *; }
-dontwarn org.bouncycastle.jsse.BCSSLParameters
-dontwarn org.bouncycastle.jsse.BCSSLSocket
-dontwarn org.bouncycastle.jsse.provider.BouncyCastleJsseProvider

# Retain OpenJSSE and Conscrypt classes and suppress warnings
-keep class org.conscrypt.** { *; }
-keep class org.openjsse.** { *; }
-dontwarn org.conscrypt.Conscrypt$Version
-dontwarn org.conscrypt.Conscrypt
-dontwarn org.conscrypt.ConscryptHostnameVerifier
-dontwarn org.openjsse.javax.net.ssl.SSLParameters
-dontwarn org.openjsse.javax.net.ssl.SSLSocket
-dontwarn org.openjsse.net.ssl.OpenJSSE

# Preserve enum values and class members
-keepclassmembers enum * { *; }

# Ensure parcelable classes and annotations are retained
-keepclassmembers class **.Parcel* { *; }

# Suppress other potential warnings (if needed)
-dontwarn okhttp3.**
-dontwarn javax.net.ssl.**

# Allow reflection for retained classes
-keepattributes *Annotation*

-dontwarn java.beans.ConstructorProperties
-dontwarn java.beans.Transient

# R8 missing optional runtime dependencies from BytePlus/Fastjson transitive modules.
# These classes are not required by the app at runtime on Android, so suppress warnings.
-dontwarn com.hihonor.android.magicx.media.audio.interfaces.AudioFeaturesKit
-dontwarn com.hihonor.android.magicx.media.audio.interfaces.HnAudioClient$ServiceType
-dontwarn com.hihonor.android.magicx.media.audio.interfaces.HnAudioClient
-dontwarn com.hihonor.android.magicx.media.audio.interfaces.HnEarReturnClient$ParameName
-dontwarn com.hihonor.android.magicx.media.audio.interfaces.HnEarReturnClient
-dontwarn com.hihonor.android.magicx.media.audio.interfaces.IAudioServiceCallback
-dontwarn java.awt.Color
-dontwarn java.awt.Font
-dontwarn java.awt.Point
-dontwarn java.awt.Rectangle
-dontwarn javax.money.CurrencyUnit
-dontwarn javax.money.Monetary
-dontwarn javax.ws.rs.Consumes
-dontwarn javax.ws.rs.Produces
-dontwarn javax.ws.rs.core.Response
-dontwarn javax.ws.rs.core.StreamingOutput
-dontwarn javax.ws.rs.ext.MessageBodyReader
-dontwarn javax.ws.rs.ext.MessageBodyWriter
-dontwarn javax.ws.rs.ext.Provider
-dontwarn org.glassfish.jersey.internal.spi.AutoDiscoverable
-dontwarn org.javamoney.moneta.Money
-dontwarn org.joda.time.DateTime
-dontwarn org.joda.time.DateTimeZone
-dontwarn org.joda.time.Duration
-dontwarn org.joda.time.Instant
-dontwarn org.joda.time.LocalDate
-dontwarn org.joda.time.LocalDateTime
-dontwarn org.joda.time.LocalTime
-dontwarn org.joda.time.Period
-dontwarn org.joda.time.ReadablePartial
-dontwarn org.joda.time.format.DateTimeFormat
-dontwarn org.joda.time.format.DateTimeFormatter
-dontwarn springfox.documentation.spring.web.json.Json