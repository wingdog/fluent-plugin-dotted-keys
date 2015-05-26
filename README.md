fluent-plugin-dotted-keys
============================

A fluentd filter that can take records with dotted keys and convert them
into deeply structured hashes.

For example, given the following record:

~~~
{
  "userId":          "f0b6d30d-d5dc-427f-899a-a2654c4189ba",
  "userRole":        "admin",
  "log.id":          "d397b870-0331-11e5-8418-1697f925ec7b",
  "log.ts":          "2015-05-25T23:01:20Z",
  "app.name":        "myapp",
  "app.instanceId":  "18825fbc-0332-11e5-8418-1697f925ec7b",
  "stat.key":        "createUser",
  "stat.count":      1,
  "stat.time":       42,
  "really.deep.key": "value"
}
~~~

This filter would produce the following deeply structured hash:

~~~
{
  "userId":       "f0b6d30d-d5dc-427f-899a-a2654c4189ba",
  "userRole":     "admin",
  "log": {
    "id":         "d397b870-0331-11e5-8418-1697f925ec7b",
    "ts":         "2015-05-25T23:01:20Z"
  },
  "app": {
    "name":       "myapp",
    "instanceId": "18825fbc-0332-11e5-8418-1697f925ec7b"
  },
  "stat": {
    "key":        "createUser",
    "count":      1,
    "time":       42
  },
  "really": {
    "deep": {
      "key":     "value"
    }
  }
}
~~~
