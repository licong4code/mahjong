
from changsha import ChangSha
from rucheng import RuCheng

def build(config):
	return globals()[config["name"]]()

# instance = build({"name":"RuCheng"})
changsha = build({"name":"ChangSha"})

# print instance.getEatGroup([1,2,3,4,5,6],4)
# print changsha.getEatGroup([1,2,3,4,5,6],4)