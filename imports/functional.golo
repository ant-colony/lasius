module functional

#function success = |value| {
#  return |success, failure| {
#    return success(value)
#  }
#}
#function failure = |message| {
#  return |success, failure| {
#    return failure(message)
#  }
#}

union Result = {
  Success = { value }
  Failure = { value }
}

augment Result {
  function bind = |this, success, failure| {
    case {
      when this oftype types.Result$Success.class {
        return success(this: value())
      }
      otherwise {
        return failure(this: value())
      }
    }
  }
}



function checkIsEqual = |item, value, err|-> match {
  when item: equals(value) then Result.Success(item)
  otherwise Result.Failure(err)
}

function checkIsNotEqual = |item, value, err|-> match {
  when item: equals(value) then Result.Failure(err)
  otherwise Result.Success(item)
}

function checkIsGreater = |item, value, err|-> match {
  when item > value then Result.Success(item)
  otherwise Result.Failure(err)
}

function checkIsLess = |item, value, err|-> match {
  when item < value then Result.Success(item)
  otherwise Result.Failure(err)
}

function checkIsEmpty = |collection, err|-> match {
  when collection: size(): equals(0) then Result.Success(collection)
  otherwise Result.Failure(err)
}

function checkIsNotEmpty = |collection, err|-> match {
  when collection: size(): equals(0) then Result.Failure(err)
  otherwise Result.Success(collection)
}

function checkIsNull = |item, err|-> match {
  when item is null then Result.Success(item)
  otherwise Result.Failure(err)
}

function checkIsNotNull = |item, err|-> match {
  when item is null then Result.Failure(err)
  otherwise Result.Success(item)
}

# --- check types ---
function checkIsString = |item, err| -> match {
  when item oftype String.class then Result.Success(item)
  otherwise Result.Failure(err)
}

function checkIsNumber = |item, err|-> match {
  when item oftype java.lang.Number.class then Result.Success(item)
  otherwise Result.Failure(err)
}

function checkIsInteger = |item, err|-> match {
  when item oftype java.lang.Integer.class then Result.Success(item)
  otherwise Result.Failure(err)
}

function checkIsLong = |item, err|-> match {
  when item oftype java.lang.Long.class then Result.Success(item)
  otherwise Result.Failure(err)
}
