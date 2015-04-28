from peewee import *
import MySQLdb
from datetime import datetime

db = MySQLDatabase(host='sql3.freesqldatabase.com', user='sql340887', password='kT6!tJ9*', port=3306, database='sql340887')

class DbModel(Model):
	class Meta:
		database = db

class Event(DbModel):
	name = CharField(null=True)
	location = CharField(null=True)
	organization = CharField(null=True)
	start_date = DateField(default=datetime.now().date())
	end_date = DateField(default=datetime.now().date())


class EventClass(DbModel):
	event = ForeignKeyField(Event, related_name='eventClasses')
	class_name = CharField()
	class Meta:
		db_table = 'event_class'


class Driver(DbModel):
	event = ForeignKeyField(Event, related_name='drivers')
	kart = CharField(null=True)
	name = CharField()
	class_id = IntegerField(null=True)
	synced_with = CharField(null=True)
	note = CharField(null=True)

class Chassis(DbModel):
	driver = ForeignKeyField(Driver, related_name='chassis')
	chassis_id = CharField()

	class Meta:
		db_table = 'driver_chassis'

class Tire(DbModel):
	driver = ForeignKeyField(Driver, related_name='tires')
	tire_id = CharField()

	class Meta:
		db_table = 'driver_tire'

class Engine(DbModel):
	driver = ForeignKeyField(Driver, related_name='engines')
	engine_id = CharField()

	class Meta:
		db_table = 'driver_engine'

class Settings(DbModel):
	tire_range = CharField()

class Scanner(DbModel):
	uuid = CharField()




db.connect()

def create_tables():
	Event.create_table(True)
	EventClass.create_table(True)
	Driver.create_table(True)
	Chassis.create_table(True)
	Tire.create_table(True)
	Engine.create_table(True)
	Settings.create_table(True)
	Scanner.create_table(True)