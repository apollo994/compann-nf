include { MAKE_OUT_FOLDERS } from '../modules/make_out_folders/main.nf'

workflow SETUP {
    main:
        MAKE_OUT_FOLDERS()
}
