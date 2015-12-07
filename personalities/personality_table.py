#! /usr/bin/env python3
"""List fields of many personalities in a table for easy comparison."""

import sys
import argparse
import logging
import csv
import os.path
import subprocess

def get_personality_dict(personality_file):
    logging.debug('EXECUTING: get_personality_dict({})'
                  .format(personality_file))

    if not os.path.exists(personality_file):
        logging.warning('personality_file does not exist: {}'
                        .format(personality_file))
        return dict(), dict()
    
    cmd = 'source {}; echo $TADAOPTS'.format(personality_file)
    optstr = subprocess.check_output(['bash', '-c', cmd ]).decode()
    options = dict()
    opt_params = dict()
    for opt in optstr.replace('-o ', '').split():
        k, v = opt.split('=')
        if k[0] != '_':
            continue
        if k[1] == '_':
            opt_params[k[2:]] = v
        else:
            options[k[1:]] = v.replace('_', ' ')                
    logging.debug('get_personality_dict({}) => popts_dict={}, pprms_dict={}'
                  .format(personality_file, options, opt_params))
    return options, opt_params


def gen_table(pfile_list, out_csvfile):
    """Output CSV table. Row per personality, column per field"""
    #print('DBG-0: pfile_list={}'.format(pfile_list))
    # First pass just to collect fields.
    fields = set()
    pdict_list = list()
    for pfile in pfile_list:
        #print('DBG: pfile={}'.format(pfile))
        pdict, prms = get_personality_dict(pfile)
        pdict['personality'] = pfile
        pdict_list.append(pdict)
        fields.update(pdict.keys())

    writer = csv.DictWriter(out_csvfile,
                            fieldnames=['personality']+list(fields))
    writer.writeheader()
    for pdict in pdict_list:
        writer.writerow(pdict)
        



##############################################################################

def main():
    "Parse command line arguments and do the work."
    parser = argparse.ArgumentParser(
        description='My shiny new python program',
        epilog='EXAMPLE: %(prog)s a b"'
        )
    parser.add_argument('--version', action='version', version='1.0.1')
    parser.add_argument('personality_files', nargs='+',
                        help='Personality files to analyze.')
    parser.add_argument('csvout', type=argparse.FileType('w'),
                        help='CSV output file')

    parser.add_argument('--loglevel',
                        help='Kind of diagnostic output',
                        choices=['CRTICAL', 'ERROR', 'WARNING',
                                 'INFO', 'DEBUG'],
                        default='WARNING')
    args = parser.parse_args()
    #!args.outfile.close()
    #!args.outfile = args.outfile.name

    #!print 'My args=',args
    #!print 'infile=',args.infile

    log_level = getattr(logging, args.loglevel.upper(), None)
    if not isinstance(log_level, int):
        parser.error('Invalid log level: %s' % args.loglevel)
    logging.basicConfig(level=log_level,
                        format='%(levelname)s %(message)s',
                        datefmt='%m-%d %H:%M')
    logging.debug('Debug output is enabled in %s !!!', sys.argv[0])

    gen_table(args.personality_files, args.csvout)

if __name__ == '__main__':
    main()
