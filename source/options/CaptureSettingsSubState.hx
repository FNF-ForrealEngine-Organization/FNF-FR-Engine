package options;

import flixel.addons.plugin.ScreenShotPlugin;

class CaptureSettingsSubState extends BaseOptionsMenu
{
    public function new() {
        title = Language.getPhrase('capture_menu', 'Capture Settings');
        rpcTitle = "Capture Settings Menu";

        var option:Option = new Option('Enable Capture',
			'If unchecked, will not able to use capture.',
			'enableCapture',
			BOOL);
		addOption(option);

        var option:Option = new Option('Save Format Type',
            'Default is PNG, JPEG or whatever idk put here.',
            'saveFormat',
            STRING,
            ['PNG', 'JPEG']);
        option.onChange = onSaveFormatType;
        addOption(option);

		var option:Option = new Option('JPEG Quality',
			'Changes how quality the JPEG images will\nWork only on JPEG images type only!.',
			'jpegQuality',
			INT);
		option.displayFormat = '%v';
		option.scrollSpeed = 10;
		option.minValue = -80;
		option.maxValue = 100;
        option.onChange = onChangeJPEGQuality;
		addOption(option);

        super();
    }

    function onSaveFormatType()
    {
        switch (ClientPrefs.data.saveFormat) {
            case "PNG": return ScreenShotPlugin.saveFormat = PNG;
            case "JPEG": return ScreenShotPlugin.saveFormat = JPEG;
        }
        return ScreenShotPlugin.saveFormat = PNG; // default value
    }

    function onChangeJPEGQuality()
        ScreenShotPlugin.jpegQuality = ClientPrefs.data.jpegQuality;
}