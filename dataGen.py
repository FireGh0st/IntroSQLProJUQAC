import random
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

student_first_date = datetime.datetime(1995, 1, 1)
student_last_date = datetime.datetime(2005, 1, 1)

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
    return f"{random.randint(100, 999)}-{random.randint(100, 999)}-{random.randint(1000, 9999)}"

def generate_random_date(start_date : datetime, end_date : datetime):
    random_date = start_date + datetime.timedelta(
        seconds=random.randint(0, int((end_date - start_date).total_seconds())),
    )

    return random_date

def generateCodePermanent(name : str, firstname : str):
    """
    Generate a code permanent based on the name and firstname of the student
    Format 'NNNFDDMMAA??'

    :param name: str
    :param firstname: str
    :return: datetime
    """
    birthdate = generate_random_date(student_first_date, student_last_date)

    return f"{name[:3].upper()}{firstname[:1].upper()}{birthdate.strftime('%d%m%-y')}{random.randint(10, 99)}"

def generatePlaque():
    """
    Generate a random license plate
    Format "AAA NNN"
    :return: str
    """
    chars = [random.choice('ABCDEFGHIJKLMNOPQRSTUVWXYZ') for _ in range(3)]
    nbs = [random.choice('0123456789') for _ in range(3)]
    return f"{''.join(chars)} {''.join(nbs)}"

#generate a new etudiant(id_etudiant, nom_etudiant, prenom_etudiant, code_permanent, numero_plaque, courriel_etudiant, telephone_etudiant, supprime, id_universite)

def generateStudent():
    lastname = random.choice(names).strip()
    firstname = random.choice(firstnames).strip()
    code_permanent = generateCodePermanent(lastname, firstname)
    numero_plaque = generatePlaque()
    courriel = f"{firstname.lower()}.{lastname.lower()}@{random.choice(emails).strip()}"
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
        cursor.execute(
            "CALL insert_etudiant(%s, %s, %s, %s, %s, %s, %s, %s)",
            (student["nom_etudiant"], student["prenom_etudiant"], student["code_permanent"], student["numero_plaque"], student["courriel_etudiant"], student["telephone_etudiant"], student["supprime"], student["id_universite"])
        )

    database.commit()
def uni_generator()


if __name__ == "__main__":
    for i in range(100):
        student = generateStudent()
        print(student)