import random
import re

import mysql.connector
import datetime

#Default values

name_reference = "references/lastname.txt"
firstname_reference = "references/firstname.txt"
email_reference = "references/email.txt"
database_host = "localhost"
database_user = "root"
database_password = ""
database_name = "projet_final_8TRD151"

student_first_date = datetime.datetime(1950, 1, 1)
student_last_date = datetime.datetime(2005, 1, 1)

alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
extanded = alphabet + '0123456789'
#Database connection
database = mysql.connector.connect(
    host=database_host,
    user=database_user,
    password=database_password,
    database=database_name
)

cursor = database.cursor()

def loadListFromFile(file : str):
    with open(file, "r") as f:
        return f.readlines()

names = loadListFromFile(name_reference)
firstnames = loadListFromFile(firstname_reference)
emails = loadListFromFile(email_reference)

#Generate a phone Number on the american format
def phoneNumberGenerator():
    return f"{random.randint(100, 999)}{random.randint(100, 999)}{random.randint(1000, 9999)}"

def generate_random_date(start_date : datetime, end_date : datetime):
    random_date = start_date + datetime.timedelta(
        seconds=random.randint(0, int((end_date - start_date).total_seconds())),
    )

    return random_date

def generateCodePermanent(name : str, firstname : str):
    """
    Generate a code permanent based on the name and firstname of the student
    Format 'NNNFDDMMAAAA'

    :param name: str
    :param firstname: str
    :return: datetime
    """
    birthdate = generate_random_date(student_first_date, student_last_date)

    return f"{name[:3].upper()}{firstname[:1].upper()}{birthdate.strftime('%d%m%Y')}"

def generatePlaque():
    """
    Generate a random license plate
    Format "AAA NNN"
    :return: str
    """
    chars = [random.choice(alphabet) for _ in range(3)]
    nbs = [random.choice('0123456789') for _ in range(3)]
    return f"{''.join(chars)} {''.join(nbs)}"

#generate a new etudiant(id_etudiant, nom_etudiant, prenom_etudiant, code_permanent, numero_plaque, courriel_etudiant, telephone_etudiant, supprime, id_universite)

def generateStudent():
    lastname = random.choice(names).strip()
    firstname = random.choice(firstnames).strip()
    code_permanent = generateCodePermanent(lastname, firstname)
    numero_plaque = generatePlaque()
    courriel = f"{firstname.lower()}.{lastname.lower()}.{random.randint(1000,9999)}@{random.choice(emails).strip()}"
    telephone = phoneNumberGenerator()
    supprime = random.choice([0, 1])
    id_universite = random.randint(1, 7)

    return {
        "nom_etudiant": lastname,
        "prenom_etudiant": firstname,
        "code_permanent": code_permanent,
        "numero_plaque": numero_plaque,
        "courriel_etudiant": courriel,
        "telephone_etudiant": telephone,
        "supprime": supprime,
        "id_universite": id_universite
    }


def pushStudents(numbers : int):
    for i in range(numbers):
        student = generateStudent()
        try:
            cursor.execute(
                "CALL NouvelEtudiant(%s, %s, %s, %s, %s, %s, %s, %s)",
                (student["nom_etudiant"], student["prenom_etudiant"], student["code_permanent"], student["numero_plaque"], student["courriel_etudiant"], student["telephone_etudiant"], student["supprime"], student["id_universite"])
            )
            database.commit()

        except mysql.connector.Error as e:
            print(e)
            print(student)


def generateAgent():
    lastname = random.choice(names).strip()
    firstname = random.choice(firstnames).strip()
    return {
        "nom_agent": lastname,
        "prenom_agent": firstname
    }

def pushAgents(numbers : int):
    for i in range(numbers):
        agent = generateAgent()
        cursor.execute(
            "INSERT INTO agent (nom_agent, prenom_agent) VALUES (%s, %s)",
            (agent["nom_agent"], agent["prenom_agent"])
        )

    database.commit()

pushStudents(500000)
pushAgents(100)

cursor.close()
database.close()
