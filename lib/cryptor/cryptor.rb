class Cryptor

  def self.encryptData(strString)
    intRnd=100
    while intRnd<0 or intRnd>9
      intRnd = (rand*10).to_i
    end
    ret = ''
    strTemp = encrypt(strString,GFN_UserEncryptArray[intRnd])
    strRet = ''
    1.upto(strTemp.length) do |i|
      pos = i-1
      strChar = strTemp[pos].bytes.to_a[0].to_s(16)
      strChar = '0'+strChar if 1==strChar.length
      strRet += strChar
    end
    ret += strRet + intRnd.to_s
  end

  def self.decryptData(strString)
    intRnd = strString[-1]
    strTemp = ''
    i = 1
    while i<=strString.length-1
      pos = i - 1
      strTemp += (strString[pos..pos+1]).to_i(16).chr
      i+=2
    end
    strText = encrypt(strTemp,GFN_UserEncryptArray[intRnd.to_i])
    strText
  end

private
  
    GFN_UserEncryptArray=["sdfdsgweg",
      "asdfssgjweh",
      "asdfssgjweh",
      "asdsdfsdfssgjweh",
      "sadf",
      "asdfiulssgjweh",
        "dfmasrtdfsdfssgjweh",
	  "gm765",
	    "m,yuliuy4",
	      "a,56i6k",
	        "457hjk"]


  def self.encrypt(strString,strKey)
    arrKey = strToArray(strKey)
    k=0
    strRet = ''
    1.upto(strString.length) do |i|
      pos = i-1
      strChar = strString[pos]
      strChar = (strChar.bytes.to_a[0]) ^ (arrKey[k].bytes.to_a[0])
      strRet += strChar.chr
      k+=1
      k=0 if k>=strKey.length
    end
    strRet
  end

  def self.strToArray(strString)
    strString.chars.to_a
  end
end
