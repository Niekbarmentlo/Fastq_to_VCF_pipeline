# Read sample names from a file
with open('Bamlist_40samples_withoutDash.txt', 'r') as file:
    sample_files = [line.strip() for line in file.readlines()]

# Function to generate Picard command
def generate_picard_command(sample_file):
    # Splitting the sample file name to extract relevant information
    parts = sample_file.split('_')
    RGSM = parts[0]  # The first part is WB10 (RGSM)
    RGLB = parts[1]  # The second part is MKDN240010405-1A (RGLB)
    RGPL = "ILLUMINA"  # Assuming the platform is ILLUMINA
    RGPU = RGSM + "_unit"  # Assuming RGPU is unit1
    RGID = RGSM + "_" + parts[2]
    
    # Constructing the output file name
    output_file = sample_file.replace(".bam", ".RG.bam")
    input_file = sample_file.replace(".bam", ".rgOLD.bam")
    
    # Constructing the Picard command
    command = f"picard AddOrReplaceReadGroups -I {input_file} -O {output_file} --RGID {RGID} --RGLB {RGLB} --RGPL {RGPL} --RGSM {RGSM} --RGPU {RGPU}"
    
    return command

# Loop through each sample file and generate the command
for sample_file in sample_files:
    picard_command = generate_picard_command(sample_file)
    print(picard_command)

