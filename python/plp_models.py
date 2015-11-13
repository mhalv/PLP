from sqlalchemy import Table, Column, String, Integer, Date, ForeignKey, Boolean, Float, DateTime
from sqlalchemy.orm import relationship, backref
from sqlalchemy.ext.declarative import declarative_base

from sqlalchemy import create_engine
from sqlalchemy.engine.url import URL
from sqlalchemy.orm import sessionmaker

import db_configs

Base = declarative_base()

class Site(Base):
    __tablename__ = 'sites'
    id = Column(Integer, primary_key=True)
    name = Column(String)
    district_id = Column(Integer)
    school_start = Column(Date)
    school_end = Column(Date)

def create_session():
    engine = create_engine(URL(**db_configs.prod_config))
    factory = sessionmaker()
    factory.configure(bind=engine)
    Base.metadata.create_all(engine)
    conn = engine.connect()
    return factory()