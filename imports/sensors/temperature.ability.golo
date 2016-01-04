module temperature.ability

import functional

----
minimal constructor for Temperature object
----
local function temperature = -> DynamicObject()
  : minTemperature(-10.0)
  : maxTemperature(10.0)
  : B(java.lang.Math.PI()/2)
  : unitsTranslatedToTheRight(java.util.Random(): nextInt(5))
  : temperatureUnit("Celsius")
  : temperatureValue(null)
  : define("amplitude", |this| ->
      (this: maxTemperature()-this: minTemperature())/2
    )
  : define("unitsTranslatedUp", |this| ->
      this: minTemperature() + this: amplitude()
    )
  : define("getTemperatureLevel", |this, t| ->
      this: amplitude() * java.lang.Math.cos(this: B() * (t - this: unitsTranslatedToTheRight())) +this: unitsTranslatedUp()
    )

----
Public constructor for Temperature object
----
function temperature = |minTemperature, maxTemperature| {

  let failures = list[]

  let res = temperature()
              : minTemperature(minTemperature)
              : maxTemperature(maxTemperature)

  checkIsNotNull(item=minTemperature, err="temperature: minTemperature must be not Null"): bind(
    success=|item| {},
    failure=|errMessage| {
      failures: add(errMessage)
      failures: add("action: minTemperature = 0")
      res: minTemperature(0)
    }
  )

  checkIsNotNull(item=maxTemperature, err="temperature: maxTemperature must be not Null"): bind(
    success=|item| {},
    failure=|errMessage| {
      failures: add(errMessage)
      failures: add("action: maxTemperature = 0")
      res: maxTemperature(0)
    }
  )

  checkIsGreater(
    item=res: maxTemperature(),
    value=res: minTemperature(),
    err="temperature: maxTemperature must be greater than minTemperature"): bind(
      success=|item| {},
      failure=|errMessage| {
        failures: add(errMessage)
        failures: add("action: maxTemperature = minTemperature")
        res: maxTemperature(res: minTemperature())
      }
  )

  checkIsEmpty(collection=failures, err="temperature: some failures:"): bind(
    success=|collection| {},
    failure=|errMessage| {
      println(errMessage)
      println(failures)
    }
  )

  return res

}