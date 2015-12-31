module functional

function success = |value| {
  return |success, failure| {
    return success(value)
  }
}
function failure = |message| {
  return |success, failure| {
    return failure(message)
  }
}

function checkIsEqual = |item, value, errMessage|-> match {
  when item: equals(value) then success(item)
  otherwise failure(errMessage)
}

function checkIsNotEqual = |item, value, errMessage|-> match {
  when item: equals(value) then failure(errMessage)
  otherwise success(item)
}

function checkIsGreater = |item, value, errMessage|-> match {
  when item > value then success(item)
  otherwise failure(errMessage)
}

function checkIsLess = |item, value, errMessage|-> match {
  when item < value then success(item)
  otherwise failure(errMessage)
}

function checkIsEmpty = |collection, errMessage|-> match {
  when collection: size(): equals(0) then success(collection)
  otherwise failure(errMessage)
}

function checkIsNotEmpty = |collection, errMessage|-> match {
  when collection: size(): equals(0) then failure(errMessage)
  otherwise success(collection)
}

function checkIsNull = |item, errMessage|-> match {
  when item is null then success(item)
  otherwise failure(errMessage)
}

function checkIsNotNull = |item, errMessage|-> match {
  when item is null then failure(errMessage)
  otherwise success(item)
}

# --- check types ---
function checkIsString = |item, errMessage|-> match {
  when item oftype String.class then success(item)
  otherwise failure(errMessage)
}

function checkIsNumber = |item, errMessage|-> match {
  when item oftype java.lang.Number.class then success(item)
  otherwise failure(errMessage)
}

function checkIsInteger = |item, errMessage|-> match {
  when item oftype java.lang.Integer.class then success(item)
  otherwise failure(errMessage)
}

function checkIsLong = |item, errMessage|-> match {
  when item oftype java.lang.Long.class then success(item)
  otherwise failure(errMessage)
}
