all:
	#make clean              # Do some clean up
	#make tools              # Prepare Swift tools
	#bundle install          # Prepare Ruby tools
	xcodegen generate       # Generate Xcode project
	#bundle exec pod install # CocoaPods
	xed .                   # Open the project in Xcode

clean:


tools:
