import yaml
from cryptography.fernet import Fernet

# Generate a random encryption key
encryption_key = Fernet.generate_key()

# Save the encryption key to a locked file (e.g., key.key)
with open("key.key", "wb") as key_file:
    key_file.write(encryption_key)

# Load the encryption key from the locked file
with open("key.key", "rb") as key_file:
    encryption_key = key_file.read()

# Load and encrypt the YAML file
with open("credentials.yaml", "rb") as yaml_file:
    yaml_data = yaml_file.read()

cipher_suite = Fernet(encryption_key)
encrypted_data = cipher_suite.encrypt(yaml_data)

# Save the encrypted data to a file (e.g., encrypted_credentials.enc)
with open("encrypted_credentials.enc", "wb") as encrypted_file:
    encrypted_file.write(encrypted_data)


# Load the encryption key from the locked file
with open("key.key", "rb") as key_file:
    encryption_key = key_file.read()

# Load and decrypt the encrypted data
with open("encrypted_credentials.enc", "rb") as encrypted_file:
    encrypted_data = encrypted_file.read()

cipher_suite = Fernet(encryption_key)
decrypted_data = cipher_suite.decrypt(encrypted_data)

# Convert the decrypted data to a YAML dictionary
credentials = yaml.safe_load(decrypted_data)

# Access the credentials
print("Username:", credentials["username"])
print("Password:", credentials["password"])
print("UUID:", credentials["uuid"])
