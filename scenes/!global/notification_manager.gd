class_name NotificationManagerInstance extends Node

func notify(title, body, ding = false):
	if Engine.has_singleton("LocalNotification"):
		var ln = Engine.get_singleton("LocalNotification")
		ln.showLocalNotification(body, title, 0, 1 if ding else 0)

func delayed_notify(title, body, delay, ding = false):
	if Engine.has_singleton("LocalNotification"):
		var ln = Engine.get_singleton("LocalNotification")
		ln.showLocalNotification(body, title, delay, 1 if ding else 0)
