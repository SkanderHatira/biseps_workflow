# -*- coding: utf-8 -*-

import sys
from Bio import SeqIO

# Genere un fichier de positions relatives entre deux jeux d elements genomiques
# Args :
# input_dmr_gff3 : un fichier gff3 d elements a comparer
# input_genome_fasta : un fichier fasta de sequence de genome
# input_geneannot_gff3 : un fichier d elements genomiques par exemple
# output_file : chemin du fichier de sortie

def fetch_close_gelements(input_dmr_gff3, input_genome_fasta, input_geneannot_gff3, output_file):

    genome_dict = init_genome_dict(input_genome_fasta)

    genome_dict = fill_genome_dict_with_annot(genome_dict, input_geneannot_gff3)

    dmr_dict = cross_genes_and_dmrs(genome_dict, input_dmr_gff3)

    gene_dict = convert_dmr_to_gene_dict(dmr_dict)

    write_results(gene_dict, output_file)




def write_results(dmr_dict, output_file):

    output_handler = open(output_file, "w")

    for gene in dmr_dict:
        for gene_match in dmr_dict[gene]:
            to_write = [gene_match[0], gene_match[1], gene_match[2], gene_match[3]]
            output_handler.write("\t".join(to_write) + "\n")





def convert_dmr_to_gene_dict(dmr_dict):

    gene_dict = {}
    for dmr in dmr_dict:

        # inside
        if dmr_dict[dmr]["inside"] != "void":
            genes_inside = dmr_dict[dmr]["inside"].split(",")
            for gene_inside in genes_inside:
                if gene_inside not in gene_dict:
                    gene_dict[gene_inside] = []


                gene_dict[gene_inside].append([gene_inside, "0", "inside", dmr])



        if dmr_dict[dmr]["left"] != "edge of chromosome":
            info = dmr_dict[dmr]["left"].split("-")
            gene_name = info[0]

            if gene_name not in gene_dict:
                gene_dict[gene_name] = []
            gene_dict[gene_name].append([gene_name, info[1], info[2], dmr])

        if dmr_dict[dmr]["right"] != "edge of chromosome":
            info = dmr_dict[dmr]["right"].split("-")
            gene_name = info[0]

            if gene_name not in gene_dict:
                gene_dict[gene_name] = []
            gene_dict[gene_name].append([gene_name, info[1], info[2], dmr])

    return gene_dict

def cross_genes_and_dmrs(genome_dict, input_dmr_gff3):

    dmr_dict = {}

    dmr_count = 0

    dmr_gff = open(input_dmr_gff3, "r")
    next(dmr_gff)
    for line in dmr_gff:
        sl = line.split("\t")
        dmr_id = sl[8].split(";")[0].split("=")[1]

        chr = sl[0]
        start = int(sl[3])
        end = int(sl[4])

        inside_dmr = list(set([elt[0] for elt in genome_dict[chr][start-1:end] if elt != -1]))

        if inside_dmr == []:
            inside_dmr = "void"
        else:
            inside_dmr = ",".join(inside_dmr)


        left_of_dmr = search_one_side(genome_dict[chr], start-1, -1)
        right_of_dmr = search_one_side(genome_dict[chr], end, 1)

        dmr_object = {"id" : dmr_id, "inside" : inside_dmr, "left" : left_of_dmr, "right": right_of_dmr}
        dmr_dict[dmr_id] = dmr_object

        dmr_count += 1
        if dmr_count % 1000 == 0:
            print(str(dmr_count) +  " dmrs processed")

    return dmr_dict

def search_one_side(genome_dict_chr, dmr_boundary, operator):

    step_count = 0
    curr_elt = -1
    curr_pos = dmr_boundary

    while curr_elt == -1:

        curr_pos += operator

        if curr_pos > 0 and curr_pos < len(genome_dict_chr):
            curr_elt = genome_dict_chr[curr_pos]
            step_count += 1

        else:
            break

    if curr_elt != -1:
        head_or_tail = head_or_tail_conversion(curr_elt[1], operator)
        return "-".join([curr_elt[0], str(step_count), str(head_or_tail)])
    else:
        return "edge of chromosome"


def head_or_tail_conversion(gene_sens, operator):
    if (gene_sens == "+" and operator == -1) or (gene_sens == "-" and operator == 1):
        return "tail"
    elif (gene_sens == "+" and operator == 1) or (gene_sens == "-" and operator == -1):
        return "head"

def fill_genome_dict_with_annot(genome_dict, input_geneannot_gff3):

    for line in open(input_geneannot_gff3, "r"):
        sl = line.split("\t")

        if sl[2] == "gene":
            chr = sl[0]
            gene_id = sl[8].split(";")[0].split(":")[1]
            start = int(sl[3])
            end = int(sl[4])
            sens = sl[6]

            gene_length = end - start + 1
            genome_dict[chr][start-1:end] = [[gene_id, sens]] * gene_length


    return genome_dict

def init_genome_dict(genome_fasta):

    genome_dict = {}

    for record in SeqIO.parse(genome_fasta, "fasta"):

        len_seq = len(str(record.seq))
        list_init = [-1] * (len_seq + 10000000)

        genome_dict[record.id] = list_init

        print(record.id + " intialization done")

    return genome_dict


fetch_close_gelements(sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4])
