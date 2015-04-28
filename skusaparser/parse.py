import csv
from peewee import *
from threading import Thread
import MySQLdb

mysql_db = MySQLDatabase(None)


class Parser(Thread):

    def __init__(self, filename, host, user, password, db, port, eventNames, queue):
        super(Parser, self).__init__()
        global mysql_db
        self.filename = filename
        self.host = host
        self.user = user
        self.password = password
        self.port = port
        self.db = db
        self.eventNames = eventNames.split(',')
        self.queue = queue
        self.daemon = True
        mysql_db.init(host=self.host, user=self.user, password=self.password, port=int(self.port), database=self.db)
        mysql_db.connect()

    def run(self):
        for event in self.eventNames:
            create_tables()
            event = Event.create(name=event.strip())
            with open(self.filename, 'rU') as csvfile:
                spamreader = csv.reader(csvfile, delimiter = ',', quotechar='"')
                self.row_count = float(sum(1 for row in spamreader))

            with open(self.filename, 'rU') as csvfile:
                spamreader = csv.reader(csvfile, delimiter = ',', quotechar='"')
                for line, row in enumerate(spamreader):
                    if line > 0:
                        try:
                            d = Driver()
                            d.event = event
                            d.name = "%s %s" % (row[2], row[1])
                            if not d.name.strip():
                                raise ValueError
                            d.kart = row[4]
                            eventclass = EventClass.get_or_create(event=event, class_name=row[3])
                            d.class_id = eventclass.id
                            d.save()
                        except:
                            pass
                    self.queue.put((line+1)*100/self.row_count)

from datetime import datetime


class DbModel(Model):
    class Meta:
        database = mysql_db

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

    class Meta:
        db_table = 'scanners'


def create_tables():
    Event.create_table(True)
    EventClass.create_table(True)
    Driver.create_table(True)
    Chassis.create_table(True)
    Tire.create_table(True)
    Engine.create_table(True)
    Settings.create_table(True)
    Scanner.create_table(True)
