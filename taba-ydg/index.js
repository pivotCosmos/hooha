const functions = require("firebase-functions");
const admin = require("firebase-admin"); //초기설정필요
const auth = require("firebase-auth");

var serviceAccount = require("./hooha-app-firebase-adminsdk-wlayu-c51b35ae47.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://hooha-app-default-rtdb.asia-southeast1.firebasedatabase.app"
});

//서버코드
//함수이름 //비동기 통신
//admin을 통해서 토큰을 발급받을수있기 때문에 서버가 꼭 필요
exports.createCustomToken = onRequest(async (request, response) => { 
    const user = request.body; //body로 들어오는 user 객체를 server에서 받는다.
//firebase의 user가 추가됨 + 추가된 user의 id를 가지고 토큰을 만들어줘야함. 근데 매번 이렇게하면 
//이미 user가 있는 상황에서도 create하는 행위가 있을수있으니 들어온 user정보 그대로 사용이 아닌 uid를 수정.
    const uid = 'kakao:${user.uid}'; //유저정보에서 uid가 들어오는것을 앞에 kakao를 붙여서 카카오쪽에서 로그인했다는것을 확인하기위함
    const updateParams = { //uid를 제외한 정보들을 가공
        email:user.email,
        photoURL:user.photoURL,
        displayName: user.displayName
    };

    try{
        await admin.auth().updateUser(uid,updateParams); //기존 계정에 바뀐부분이있으면 업데이트
    } catch(e){
        updateParams["uid"]=uid;
        await admin.auth().createUser(updateParams); //id가 등록이안되어있을 시 id를 넣어서 create
    }


    await admin.auth().createCustomToken(uid); //uid로 등록된 사용자의 토큰을 여기서 만들어줌.

    response.send(token); //토큰 돌려줌

});
