import os, glob, subprocess

files = glob.glob(os.path.join("Pokemon XY", "*", "*.dae")) + glob.glob(os.path.join("Pokemon XY", "*", "*.DAE"))
# output_folder = "3D Models"
# os.makedirs(output_folder, exist_ok=True)

def export_models(file):
    par_dir = os.path.abspath(os.path.join(file, os.pardir))
    cmd = [
        '/Applications/Xcode.app/Contents/Developer/usr/bin/scntool',
        '--convert',
        file,
        '--format',
        'scn',
        '--output',
        os.path.join(par_dir, file.split(os.sep)[-1].split('.')[0] + '.scn'),
        '--target-build-dir=' + par_dir,
        # '-c',
        # '--resources-path-prefix',
        # output_folder,
        # '--resources-folder-path=' + output_folder,
        '--asset-catalog-path',
        par_dir,
        '--copy',
        '--force-y-up',
        '--force-interleaved',
        '--prefer-compressed-textures',
        # '--look-for-pvrtc-image',
        # '--verbose',
    ]
    print(f"Excuting command : {' '.join(cmd)}")
    subprocess.run(cmd)

for path in files:
    export_models(path)