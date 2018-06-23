@jay_test
Feature: GitHub API Test - Get Repo

Background: GitHub API Test - Get Repo
	#put more common stuff in here. each scenario will use these values
	* def userName = "jaylara"
	* def repoName = "jaydata"
	
	
Scenario: Test Get Repo Information
	
# Do it this way, or...
#	Given url cApiUrl
#	And replace enpointRepo.user_name = userName
#	And replace enpointRepo.repo_name = repoName
#	And path enpointRepo
#	And header Accept = cHeaderAccept
#	When method GET
#	Then status 200
#	And def repositoryResponse = response

#Do it this way with a resusable feature
	Given def repositoryResponse = call read('classpath:resusable/features/fetchRepo.feature') { userName: '#(userName)', repoName: '#(repoName)' }
	When match repositoryResponse.responseStatus == 200
	Then def repositoryResponse = repositoryResponse.savedResponse
	
	
	#assuming these objects came from the database or some "external source".
	* def dbRepoInfo = 
	"""
	{
		id: '#(repositoryResponse.id)',
		name: '#(repositoryResponse.name)'
	}
	"""
	* def dbOwnerInfo = 
	"""
	{
		id: '#(repositoryResponse.owner.id)',
		login: '#(repositoryResponse.owner.login)'
	}
	"""
	
	#check that dummy "external source" returned correct username and repo
	And match dbRepoInfo.name == repoName
	And match dbOwnerInfo.login == userName
	
	#check response returned correct username and repo
	And match repositoryResponse.owner.login == userName
	And match repositoryResponse.name == repoName
	
	#test avatar link is formed correctly and resolves
	And def expected_avatar_url =  "https://avatars1.githubusercontent.com/u/" + dbOwnerInfo.id
	And match repositoryResponse.owner.avatar_url contains expected_avatar_url
	
	#test avatar link resolves
	Given url repositoryResponse.owner.avatar_url
	When method GET
	Then status 200
	And match responseHeaders['Content-Type'][0] == "image/jpeg"



Scenario: Test Get Repo Information - Invalid Repo
	Given def repositoryResponse = call read('classpath:resusable/features/fetchRepo.feature') { userName: '#(userName)', repoName: 'this_is_bad_repo' }
	When match repositoryResponse.responseStatus == 404
	Then def repositoryResponse = repositoryResponse.savedResponse
	And match repositoryResponse ==
	"""
	{
		"message": "Not Found",
		"documentation_url": "https://developer.github.com/v3/repos/#get"
	}
	"""
	
Scenario: Test Get Repo Information - Invalid User
	Given def repositoryResponse = call read('classpath:resusable/features/fetchRepo.feature') { userName: 'what_user_am_i', repoName: '#(repoName)' }
	When match repositoryResponse.responseStatus == 404
	Then def repositoryResponse = repositoryResponse.savedResponse
	And match repositoryResponse ==
	"""
	{
		"message": "Not Found",
		"documentation_url": "https://developer.github.com/v3/repos/#get"
	}
	"""


@ignore
Scenario: This is just an empty scenario showing usage of @ignore tag
	* def name = "I do not remember my name"
	* print name