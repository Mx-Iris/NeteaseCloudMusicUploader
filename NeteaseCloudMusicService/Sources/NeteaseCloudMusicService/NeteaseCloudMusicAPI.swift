import Foundation
import Papyrus
import NeteaseCloudMusicModel

@API
@Mock
protocol NeteaseCloudMusic {
    @GET("/login/cellphone")
    func mobileLogin(phone: String, password: String, countrycode: Int?, captcha: String?) async throws -> LoginResponse

    @GET("/captcha/sent")
    func sentCaptcha(phone: String, ctcode: Int?) async throws
    
    @GET("/login")
    func mailLogin(email: String, password: String) async throws -> LoginResponse

    @GET("/login/qr/key")
    func qrcodeLoginKey() async throws -> QRCodeKeyResponse

    @GET("/login/qr/create")
    func qrcodeLoginCreate(key: String) async throws -> QRCodeCreateResponse

    @GET("/login/qr/check")
    func qrcodeLoginCheck(key: String) async throws -> QRCodeCheckResponse

    @Multipart
    @POST("/cloud")
    func uploadCloudSongFile(_ songFile: Part) async throws

    @GET("/user/cloud")
    func cloudSongList(limit: Int, offset: Int) async throws -> CloudSongList

    @GET("/cloud/match")
    func cloudSongMatch(uid: Int, sid: Int, asid: Int) async throws

    @GET("/login/status")
    func loginStatus() async throws -> LoginStatus
    
    @POST("/logout")
    func logout() async throws
}
