from sqlalchemy import Table, Column, String, Integer, Date, ForeignKey, Boolean, Float, DateTime
from sqlalchemy.orm import relationship, backref
from sqlalchemy.ext.declarative import declarative_base

from sqlalchemy import create_engine
from sqlalchemy.engine.url import URL
from sqlalchemy.orm import sessionmaker

import db_configs

Base = declarative_base()

def create_session():
    engine = create_engine(URL(**db_configs.analytics_config))
    factory = sessionmaker()
    factory.configure(bind=engine)
    Base.metadata.create_all(engine)
    conn = engine.connect()
    return factory()

def create_connection():
    engine = create_engine(URL(**db_configs.analytics_config))
    return engine.connect()