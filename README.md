# ☀️WeatherForecast☀️
Swift로 구현한 날씨정보 앱
---
- 진행기간: 2021-10-08 ~ 2021-10-22
  진행기간 이후에 여러번에 걸쳐 리펙토링을 진행하였습니다. 
- camper: [tacocat](https://github.com/Ldoy), [yun](https://github.com/blanche37)

  
### Index
- [실행화면](#실행화면)
- [OpenAPI](#OpenAPI)
- [Architecture](#Architecture)
- [학습내용](#학습내용)
- [FlowChart](#FlowChart)
- [Implementation](#Implementation)

### 실행화면
![](https://i.imgur.com/scVyTuJ.gif)

### OpenAPI
[OpenWeatherAPI](https://openweathermap.org/)의 CurrentWeatherData와 5 Day / 3 Hour Forecast를 활용하여 앱을 만들었습니다. 


### Architecture
MVVM

### FlowChart

## 학습내용 
1.Singleton과 static 프로퍼티의 차이점과 어떤 경우에 사용하는 것이 바람직한지 생각해보았습니다. 예를들어, `CachingManager`의 경우 초기화될경우 그동안 저장했던 데이터가 날아갈 수도 있다는 생각에 `singleton`으로 구현하여, 이니셜라이저에 대한 접근을 막았습니다. 이와같이 인스턴스를 하나만 가져야 할때가 아니라면, static이나 공유인스턴스를 사용할 수 있겠다는 생각을 해 보았습니다.
2.처음에는 MVC로 개발을 했었는데, `ViewController`에 View와 관련된 코드, delegate와 관련된 코드 등이 전부 포함되어, 가독성이 상당히 떨어지는 느낌을 받아, MVVM으로 리펙토링을 진행하였습니다. 데이터 바인딩은 `Observable`클래스를 활용하였습니다.
3.`Clean Architecture`에 대한 고민을 해보고, 리펙토링을 진행하였습니다.
4.동적인 배경화면을 적용해보고 싶어서 `Lottie`에 대해서 알아보았습니다.
5.`UITest`와 `UnitTest`에 대해서 고민해 보았습니다.

## Implementation
1.`SwiftLint`로 나만의 룰 만들어보기
2.`SnapKit`을 활용한 코드로 오토레이아웃 구현
3.`CLLocationManager`를 활용해서 위치정보 받아오기
4.`Alamofire`를 통한 네트워킹
5.`Observable`타입을 활용한 데이터바인딩 
6.`NSCache`를 활용한 이미지 캐시 구현
7.`Lottie`를 활용해 배경 애니메이션 적용해보기

### 1.SwiftLint를 사용한 룰 적용
SwiftLint로 나만의 룰을 만들어 적용하였습니다.
룰을 하나하나 살펴보면서 어떤식으로 코드를 작성하면 가독성에 좋을지 생각해보았습니다.

### 2.SnapKit을 활용한 코드로 오토레이아웃 구현
이전에 외부라이브러리 사용없이 코드로 오토레이아웃을 구현해본적이 있어서,
```swift=
view.translatesAutoresizingMaskIntoConstraints = false
```
와 같은 중복코드를 줄이고, 선언형으로 오토레이아웃을 작성하기 위해, `SnapKit`을 활용하였습니다.
### 3.CLLocationManager를 활용해서 위치정보 받아오기
CLLocationManager를 활용해서, 실행직후 위치정보 동의를 얻은 후, 위치정보를 얻어, 화면에 업데이트 해주었습니다.
또한, 위치가 변경될때 마다 위치정보를 ViewModel에 업데이트하고, RefreshControl을 동작시키면, 업데이트 되도록 설정하였습니다.


### 4.Alamofire를 통한 네트워킹
과거에 URLSession을 이용하여 네트워킹을 한 경험이 있어서, Alamofire를 사용해 보았습니다. 
결과로, 반복되는 Boilerplate코드가 많은 줄은 것 같습니다.

### 5.Observable타입을 활용한 데이터바인딩
Observable을 활용해 Model의 값이 바뀌면, ViewModel이 View에 의존하지 않아도 자동적으로 UI가 업데이트 되도록 설정하였습니다.

### 6.NSCache를 활용한 이미지 캐시 구현
화면버벅임을 방지하기위해 이미지 캐싱을 진행하였습니다.

### 7.Lottie를 활용해 배경 애니메이션 적용해보기
Lottie를 활용해서 동적인 배경화면을 적용해보았습니다.
